###################################################################
# NAME: Storage_Tools.ps1
# AUTHOR: Sean Harper, Ford Motor Company
# VERSION HISTORY:
#	Rev1: 6/8/2010, sharpe19
# COMMENT: Performs the automated failover steps defined by TPC-R
###################################################################
# Key Files:
# tpcrcli-auth.properties - contains user name and password for session
# session.properties - contains session information for the affected storage
# servers.properties - contains the TPC-R servers to try to connect to
# actions.properties - contains valid actions which TPC-R operators can perform
# debug.properties - debugging verbosity level for TPC-R
#
# Deployment Notes:

# set-psdebug –strict

# Define global values
# Build information
$BuildVersion = [int] 101
$zipfile = [string] "storage_tools-windows.zip"
$scriptfile = [string] "storage_tools.ps1"
$verfile = [string] "storage_tools-windows.ver"

# Advanced Options
$flgAdvanced = "FALSE"
$flgDebug = "TRUE" #*#
$strLoggedInUser = $env:USERNAME

# Logging information
$LogDirPath = "C:\storage_tools\Logfiles\"
$LogFilePathName = "TPCR_Actions.log"
$LogFileFullPath = "C:\storage_tools\Logfiles\TPCR_Actions.log"

# Soft file paths
$strSessionFileFolderBasePath = $env:USERPROFILE
$strSessionFileFolderPath = $strSessionFileFolderBasePath + "\tpcr-cli\" 
$AuthFileFullPath = $strSessionFileFolderBasePath + "\tpcr-cli\tpcrcli-auth.properties"
$SessFileFullPath = $strSessionFileFolderBasePath + "\tpcr-cli\session.properties"
$ServFileFullPath = "C:\storage_tools\csmscripts\cli_script\servers.properties"

cls

If (!(Test-Path $LogFileFullPath))
	{
	New-Item -path $LogDirPath -name $LogFilePathName -type file -force
	}

#####################################################################
# Define all functions before calling main routines and subroutines #
#####################################################################

##########################################################
# retrieves session ID from tpcrcli-auth.properties file #
##########################################################
Function GetSessionUserID
{
# Check for existence and file size of 
If (!(Test-Path ($AuthFileFullPath)))
	{
	LogAndEchoError ("File not found: $AuthFileFullPath `nPlease refer to the runbook for creating/editing this file")
	Exit
	}

Foreach ($line in Get-Content($authFileFullPath))
	{
	$Global:GetSessionID = $line | Where {$_.IndexOf("username") -eq 0}
	}

$GetSessionID = $GetSessionID.Replace("username=","")

If ($GetSessionID -ne $strLoggedInUser)
	{
	LogAndEchoError ("You must be logged in as the proxy account ($GetSessionID) to which the session has rights assigned.  `nSee Infrastructure DR Template for details.  Exiting script.")
	#*#Exit
	}

LogAndEcho ("Found session user ID: " + $GetSessionID + " in " + $AuthFileFullPath)

} # End GetSessionID

#############################################
# checks for the global inputs to read-host #
#############################################
Function ProcessInput
{
switch ($args)
	{
	"BACK" {NestedMenus}
	"MAIN" {NestedMenus}
	"HELP" {DisplayUsage}
	"Q" {Exit}
	"QUIT" {Exit}
	default {}
	}

} #End ProcessInput

#################################################
# Pass parameters to the tpcr-action.pl command #
#################################################
Function TPCRActionToPerl
{
$strType = $args[0]
$strAction = $args[1]
$strSession = $args[2]

# translation logic for target type (MM or FC) and session (boot, data, or both)
If ($strType = "MM")
	{
	If ($strSession -eq "both")
	{$strTPCRSession = "mmboot","mmdata"}
	ElseIf ($strSession = "boot")
        {$strTPCRSession = "mmboot"}
    ElseIf ($strSession = "data")
        {$strTPCRSession = "mmdata"}
    #ElseIf ($strSession -eq $NULL) #used as a default value to check status, get state, etc.
	#	{$strTPCRSession = "mmboot"}
    Else
		{$strTPCRSession = $strType + $strSession}
	}
ElseIf ($strType = "FC")
	{
	If ($strSession -eq "boot")
		{$strTPCRSession = $strType + $strSession}
	ElseIf ($strSession -eq "data")
		{LogAndEchoError "I really haven't figured out how to do this yet"}
	ElseIf ($strTPCRSession -eq $NULL)
		{
		LogAndEchoError "Error in Flash Copy session definition"
		DisplayUsage
		NestedMenus
		}
	Else
		{
		DisplayUsage
		NestedMenus
		}
	}
ElseIf ($strType -eq $NULL)
	{$strType = "MM"}
Else
	{
	LogAndEchoError "Please review the help information on determining a session type definition"
	DisplayUsage
	NestedMenus
	}
	
# translation logic for TPC-R actions
switch ($strAction)
	{
	STAT {$strTPCRAction = "get_status", "get_state", "get_activehost"}
	CONN {$strTPCRAction = "test_conn"}
	MMSO {$strTPCRAction = "get_activehost", "get_state", "get_status", "suspend", "recover", "enable_copy_to_site_1", "start_h2:h1", "get_state"} #MetroMirror Switchover
	MMSB {$strTPCRAction = "get_activehost", "get_state", "get_status", "suspend", "recover", "enable_copy_to_site_2", "start_h1:h2", "get_state"} #MetroMirror Switchback
	MMFO {$strTPCRAction = "get_activehost", "get_state", "get_status", "suspend", "recover", "get_state"} #MetroMirror Failover
	MMBK {$strTPCRAction = "get_activehost", "get_state", "get_status", "enable_copy_to_site_1", "start_h2:h1", "get_state"} #MetroMirror Failback and Keep
	MMBP {$strTPCRAction = "get_activehost", "get_state", "get_status", "start_h1:h2", "get_state"} #MetroMirror Failback and Purge
	MMBR {$strTPCRAction = "get_activehost", "get_state", "get_status", "start_h1:h2", "get_state"} #Restart mirror after boot flash restore
	MMDR {$strTPCRAction = "get_activehost", "get_state", "get_status", "start_h2:h1", "get_state"} #Restart mirror after data flash restore
	FCBF {$strTPCRAction = "get_status", "flash", "get_status", "terminate"} #Flash copy boot volume
	FCBR {$strTPCRAction = "get_status", "flash", "get_status", "terminate"} #Flash restore boot volume
	FCDF {$strTPCRAction = "get_status", "flash", "get_status", "terminate"} #Flash copy data volume
	FCDR {$strTPCRAction = "get_status", "flash", "get_status", "terminate"} #Flash restore data volume
	TRIP {$strTPCRAction = "get_state", "get_status", "suspend", "recover", "get_state", "enable_copy_to_site_1", "start_h2:h1", "get_state", "suspend", "recover", "get_state", "enable_copy_to_site_2", "start_h1:h2", "get_state"} #Round trip - testing only
	OGUI {OpenInternetExplorer}
	OCSM {OpenCSMCommandLine}
	default {DisplayUsage; NestedMenus}
	}

Foreach ($strTPCRSessionArrayEntry in $strTPCRSession)
	{
	Foreach ($strTPCRActionArrayEntry in $strTPCRAction)
		{
		LogAndEcho("Preparing action: " + $strTPCRActionArrayEntry + " on " + $strTPCRSessionArrayEntry)
		$output = C:\Progra~1\perl\bin\perl.exe C:\storage_tools\csmscripts\cli_script\tpcr_action.pl `--action $strTPCRActionArrayEntry `--session $strTPCRSessionArrayEntry | Out-String
		EchoDebug C:\Progra~1\perl\bin\perl.exe C:\storage_tools\csmscripts\cli_script\tpcr_action.pl `--action $strTPCRActionArrayEntry `--session $strTPCRSessionArrayEntry
		EchoDebug strType = $strType
		EchoDebug strSession = $strSession
		EchoDebug strAction = $strAction
		EchoDebug strTPCRSession = $strTPCRSession
		EchoDebug strTPCRAction = $strTPCRAction
		EchoDebug strTPCRActionArrayEntry = $strTPCRActionArrayEntry
		EchoDebug strTPCRSessionArrayEntry = $strTPCRSessionArrayEntry
		LogAndEcho $output
		
		If ($strTPCRActionArrayEntry -eq "get_status")
			{
			$output = $output.Split(",")
			If ($output[3] -ne "Yes")
				{
				If ($strTPCRAction -eq "MMBK" -or $strAction -eq "MMBP" -or $strAction -eq "MMSB")
					{
					LogAndEchoError "Error performing $strTPCRActionArrayEntry on $strTPCRSessionArrayEntry.  Contact Storage Operations."
					#*#Exit
					}
				ElseIf ($strType -eq "FC")
					{
					EchoDebug "Copying in progress"
					TPCRActionToPerl $strType STAT strTPCRSessionArrayEntry
					}
				}
			If ($output[5] -ne "100" -and ($strTPCRAction -eq "MMBK" -or $strAction -eq "MMBP"))
				{
				EchoDebug "Fifth dimension of output: " $output[5]
				LogAndEcho "Waiting for copy action to complete."
				TPCRActionToPerl $strType, "get_status", $strTPCRSessionArrayEntry
				}
			Else 
				{
				EchoDebug "Status Check passed. Performing actions on storage."
				}
		 	}
		If ($strTPCRActionArrayEntry -eq "get_state")
			{
			If (!($output.Contains("Target Available") -or $output.Contains("Prepared")))
				{
				EchoDebug "State in transition.  If you see this message more than 3 times, an error has occurred with TPC-R.  Contact Storage Operations."
				Sleep 3
				TPCRActionToPerl $strType, "get_state",  $strTPCRSessionArrayEntry
				}
			If ($output.Contains("Target Available") -and $strAction -eq "MMSB")
				{
				LogAndEchoError "Session detected in failover mode.  Please perform a failback option"
				NestedMenus
				}
			}
		If ($strTPCRActionArrayEntry -eq "get_activehost")
			{
			If ($output.Contains("H2"))
				{
				If ($strAction -eq "MMFO" -or $strAction -eq "MMSO")
					{
					LogAndEchoError "Unable to perform failover or switchover action as the mirror direction is H2->H1. `nPlease perform a failback or switchback action"
					NestedMenus
					}
				}
			Elseif ($output.Contains("H1"))
				{
				If ($strAction -eq "MMBK" -or $strAction -eq "MMBP" -or $strAction -eq "MMSB")
					{
					LogAndEchoError "Unable to perform failback or switchback action as the mirror direction is H1->H2. `nPlease perform a failover or switchover action"
					NestedMenus
					}
				}
			}
		If ($strTPCRActionArrayEntry -eq "test_conn")
			{
			$strMatch = [regex] "\w*\.\w*\.\w*\.com"
			$Global:strTPCRServerName = $strMatch.Matches($output)
			}
		}
	}
#NestedMenus
} # End TPCRActionToPerl

##############################################################
# Checks the build version in the file name of the .ps1 file #
##############################################################
Function CheckBuildVersion
{
LogAndEcho "Current Build: " $BuildVersion
Foreach ($Global:line in Get-Content("C:\Temp\$verfile"))
	{
	If ($line.IndexOf('$BuildVersion') -eq 0)
		{
		$NewBuildVersion = [int] $line.substring($line.length - 4,3)
		If ($NewBuildVersion -gt $BuildVersion)
			{
			LogAndEcho "Build version $NewBuildVersion detected."
			LogAndEcho "Opening Internet Explorer to download new version of Storage_Tools.ps1"
			LogAndEcho "Please download and place the file at C:\Storage_Tools\scripts\Windows"
			EchoDebug "C:\Program Files (x86)\Internet Explorer\iexplore.exe" $Global:BaseURL + storage_tools.ps1
			. "C:\Program Files (x86)\Internet Explorer\iexplore.exe" $Global:BaseURL + storage_tools.ps1
			#*#Exit
			}
		ElseIf ($NewBuildVersion -lt $BuildVersion)
			{
			LogAndEchoError "Build version $NewBuildVersion detected. `nThis version is detected as newer than the released version.  `nPlease consult Server Engineering regarding this error"
			#*#Exit
			}
		}
	}

} #End CheckBuildVersion 

##################################################
# get the most updated scripts from TPC-R server #
##################################################
Function GetUpdates
{
# download the file, passing the path as an argument
$wc = New-Object System.Net.WebClient
$file = $args[0]
$destination = $args[1]

$Global:BaseURL = C:\Progra~1\perl\bin\perl.exe C:\storage_tools\csmscripts\cli_script\tpcr_action.pl `--action get_webserver
#Remove comment from preceding line and remove following line once Kevin's package is updated
#$Global:BaseURL = "http://vmqac6969.qac2.qford.com:81/" #QAC Testing
$url = "$Global:BaseURL$file"

LogAndEcho "Fetching" $url
EchoDebug $url, $destination\$file
$wc.DownloadFile($url,"$destination\$file")

If ($file.substring($file.length - 3, 3) -eq "zip")
	{
	EchoDebug "Zip file detected"
	$shellApplication = new-object -com shell.application
	LogAndEcho "Unzipping" $file
	Write-Host "Please note, if you get prompted for an action on the Windows directory, please review folder contents to check for newer version of this script file." -foregroundcolor Green
	$zipPackage = $shellApplication.NameSpace("$destination\$file")
	$zipdestinationFolder = $shellApplication.NameSpace("C:\")
	$zipdestinationFolder.CopyHere($zipPackage.Items(),16)
	}

} #End GetUpdates

#######################################
#Load TPC-R server name into variable #
#######################################
Function LoadTPCRServerName
{
LogAndEcho "Locating primary TPC-R server"
TPCRActionToPerl $NULL CONN $NULL
LogAndEcho "Server name $Global:strTPCRServerName found in $ServFileFullPath"
} #End LoadTPCRServerName

#######################################
# used to display help/use for script #
#######################################
Function DisplayUsage
{
$strHelpUsage = "`nThe following is the syntax to execute the Storage_Tools.ps1 script:`n"
$strHelpUsage +=  "From a Powershell command prompt, type: C:\storage_tools\scripts\Windows\Storage_Tools.ps1`n"
$strHelpUsage += "`n"
$strHelpUsage += "Valid MetroMirror Actions:`n"
$strHelpUsage += "SWITCHOVER: Performs a switchover, which suspends the mirror relationship, recovers, reverses the copy process and starts copying from production site to mirror site.`n"
$strHelpUsage += "SWITCHBACK: Performs a switchback, which suspends the mirror relationship, recovers, reverses the copy process and starts copying from mirror site to production site.`n"
$strHelpUsage += "FAILOVER: Performs a failover, which suspends the mirror relationship and recovers the relationship`n"
$strHelpUsage += "FAILBACK PURGE: Performs a failback, which overwrites the data on the primary disk, starts the copy process suspends the copy process once again, recovers the relationship once again, enables the copy process from mirror site to production site, and starts that copy process.`n"
$strHelpUsage += "FAILBACK KEEP: Performs a failback, which re-enables the copy process from production site to mirror site, starts the copy process suspends the copy process once again, recovers the relationship once again, enables the copy process from mirror site to production site, and starts that copy process.`n"
$strHelpUsage += "Valid FlashCopy Actions:`n"
$strHelpUsage += "BOOT SESSION FLASH: Performs a flash copy of the boot LUN to a flash volume, checks status until flash is complete, and terminates the flash session`n"
$strHelpUsage += "BOOT SESSION RESTORE: Checks the status of the boot LUN flash volume, terminates the mirror relationship, restores the flash, quiesces the flash session, and restores the mirror relationship`n"
#$strHelpUsage += "DATA SESSION FLASH: Performs a flash copy of the data LUN to a flash volume, checks status until flash is complete, and terminates the flash session`n"
#$strHelpUsage += "DATA SESSION RESTORE: Checks the status of the data LUN flash volume, terminates the mirror relationship, restores the flash, quiesces the flash session, and restores the mirror relationship`n"
$strHelpUsageAdv = "`n***Advanced Actions***`n"
$strHelpUsageAdv += "SUSPEND:  The first step of the fail/switch, breaks the mirror`n"
$strHelpUsageAdv += "RECOVER:  The second step of the fail/switch, prepares the mirror in reverse direction but not does engage the target`n"
$strHelpUsageAdv += "ENABLE COPY:  Prepares the target volumes to receive data (H1 is primary DC, H2 is secondary DC)`n"
$strHelpUsageAdv += "START COPY:  Begins the mirror process/data write (H1 is primary DC, H2 is secondary DC)`n"
$strHelpUsageAdv += "***Manual Functions***`n"
$strHelpUsageAdv += "TPC-R GUI:  The GUI interface for the TPC-R product, used when command line functions do not work or are ineffective.`n"
$strHelpUsageAdv += "TPC-R CLI:  The underlying technology beneath this script.  Storage Engineering has provided Perl scripts which perform the CLI actions.`n"
$strHelpUsageAdv += "***Script Functions:***`n"
$strHelpUsageAdv += "CHANGE SESSION NAME:  Edits the %USERPROFILE%\tpcr-cli\session.properties file to reflect new session names`n"
$strHelpUsageAdv += "CHANGE USER IDENTITY:  Edits the %USERPROFILE%\tpcr-cli\tpcrcli-auth.properties file to reflect new proxy account`n"
$strHelpUsageAdv += "CHANGE USER PASSWORD:  Edits the %USERPROFILE%\tpcr-cli\tpcrcli-auth.properties file to reflect new proxy account password`n"

If ($flgAdvanced -eq "TRUE")
	{
	$strHelpUsage = $strHelpUsage + "`n" + $strHelpUsageAdv
	}
$MsgBox = new-object -comobject wscript.shell
$Output = $MsgBox.popup($strHelpUsage,0,"Storage Tools Help")
} # End DisplayUsage



##############################################################
# used to drive the custom menu set (extended functionality) #
##############################################################
Function NestedMenus
{
$strSelectAction = $NULL
$strMMFCChoice = $NULL
$strMainMenu = $NULL

Write-Host "Please follow the choices below to perform storage-based actions"
Write-Host "For more information on the choices below, enter Help"
Write-Host "To exit this script, enter Q or Quit"
Write-Host ""
Write-Host "To perform MetroMirror functions, enter MM"
Write-Host "To perform FlashCopy functions, enter FC"
If ($flgAdvanced -ne "FALSE")
	{
	Write-Host ""
	Write-Host "-----Advanced Functions-----"
	Write-Host "To perform a round trip (functionality) test, enter TRIP"
	Write-Host "To perform the steps manually from the TPC-R GUI, enter OGUI"
	Write-Host "To open a TPC-R CLI session, enter OCSM"
	}

$strMainMenu = Read-Host "::"
$strMainMenu = $strMainMenu.ToUpper()
ProcessInput $strMainMenu

switch ($strMainMenu)
	{
	MM {
		Write-Host "To perform MetroMirror actions on the boot session (MMBoot), enter Boot"
		Write-Host "To perform MetroMirror actions on the data session (MMData), enter Data"
		Write-Host "To perform MetroMirror actions on both sessions, enter Both"
		Write-Host "PLEASE NOTE:  Most MetroMirror jobs should use the Both selection." -foregroundcolor Green
		$strMMFCChoice = Read-Host "::"
		$strMMFCChoice = $strMMFCChoice.ToUpper()
		ProcessInput $strMMFCChoice
		Write-Host "-----MetroMirror Actions-----"
		Write-Host "To query the status of a session or sessions, enter STAT"
		Write-Host "To perform a connectivity test, enter CONN"
		Write-Host "To perform a switchover, enter MMSO"
		Write-Host "To perform a failover, enter MMFO"
		Write-Host "To perform a switchback, enter MMSB"
		Write-Host "To perform a failback and retain data from Site 2, enter MMBK"
		Write-Host "To perform a failback and purge data from Site 2 (retain Site 1 data), enter MMBP"
		$strSelectAction = Read-Host "::"
		$strSelectAction = $strSelectAction.ToUpper()
		ProcessInput $strMMFCChoice
		}
	FC {
		Write-Host "To perform FlashCopy actions on the boot session (FCBoot), enter Boot"
		Write-Host "To perform FlashCopy actions on the primary data session (FCDataMirror1), enter Data"
		Write-Host "To perform FlashCopy actions on more than one session, contact Storage Operations" -foregroundcolor Green
		$strMMFCChoice = Read-Host "::"
		$strMMFCChoice = $strMMFCChoice.ToUpper()
		ProcessInput $strMMFCChoice
		Write-Host "-----FlashCopy Actions-----"
		Write-Host "To query the status of a session or sessions, enter STAT"
		Write-Host "To perform a connectivity test, enter CONN"
		Write-Host "To perform a boot session flash, enter FCBF"
		Write-Host "To perform a boot session restore, enter FCBR"
		#Write-Host "To perform a data session flash, enter FCDF"
		#Write-Host "To perform a data session restore, enter FCDR"
		$strSelectAction = Read-Host "::"
		$strSelectAction = $strSelectAction.ToUpper()
		ProcessInput $strMMFCChoice
		}
	Q {exit}
	QUIT {exit}
	BACK {NestedMenus}
	DEFAULT {DisplayUsage;NestedMenus}
	}
TPCRActionToPerl $strMainMenu $strSelectAction $strMMFCChoice
	
} # End NestedMenus

################################################################
# used to make sure the TPC returns are not errors or warnings #
################################################################
Function TPCErrorCheck
{
$strResults = $args[0]

switch ($strResults.substring(8,1))
	{
	"E" {LogAndEchoError "ERROR: " + $strResults}
	"W" {LogAndEcho "WARNING: " + $strResults}
	"I" {LogAndEcho "The TPC-R task returned success."}
	default {LogAndEchoError("ABNORMAL RETURN: " + $strResults)}
	}
}

####################################################
# Sub to open interactive CSM/TPC-R command prompt #
####################################################
Function OpenCSMCommandLine
{
LogAndEcho("C:\storage_tools\csmcli\csmcli.bat -server " + $Global:strTPCRServerName)
Invoke-Item("C:\storage_tools\csmcli\csmcli.bat -server " + $Global:strTPCRServerName)
} # End OpenCSMCommandLine

#####################################################
# Sub to open Internet Explorer for TPC-R GUI usage #
#####################################################
Function OpenInternetExplorer
{
LogAndEcho("C:\storage_tools\csmcli\csmcli.bat -server " + $Global:strTPCRServerName)
Invoke-Item("iexplore.exe https://" + $Global:strTPCRServerName + ":3443/CSM")
} # End OpenInternetExplorer

#########################################
# used for logging and output to screen #
#########################################
Function LogAndEcho
{
If ($args[0] -ne "-batch")
	{
	Write-Host $args -foregroundcolor yellow	
	}
Add-Content -path $LogFileFullPath -value $args
} # End LogAndEcho

#####################################################
# used for error logging and error output to screen #
#####################################################
Function LogAndEchoError
{
If ($args[0] -ne "-batch")
	{
	Write-Host $args -foregroundcolor red
	}
Add-Content -path $LogFileFullPath -value $args.ToString()
} # End LogAndEchoError

#####################################################
# used for error logging and error output to screen #
#####################################################
Function EchoDebug
{
If ($flgDebug = "TRUE")
	{
	Write-Host $args -foregroundcolor darkcyan
	Add-Content -path $LogFileFullPath -value $args.ToString()
	}
} # End EchoDebug

## Pre-work before all of the subroutines are called ##

$ArgNum = 0

# While loop that populates variables with all the user supplied arguments
While ($ArgNum -lt $args.Count)
	{
	If ($args[0] -eq "-batch")
		{
		switch ($args[1])
			{
			BFCB #Batch flash copy boot volume
				{
				$strTPCRBatchType = "FC"
				$strTPCRBatchAction = "get_status", "flash", "get_status", "terminate"
				$strTPCRBatchSession = "BOOT"
				} 
			BFCD #Batch flash copy data volume
				{
				$strTPCRBatchType = "FC"
				$strTPCRBatchAction = "get_status", "flash", "get_status", "terminate"
				$strTPCRBatchSession = "DATA"
				} 
			default {}
			}
		TPCRActionToPerl $strTPCRBatchType $strTPCRBatchAction $strTPCRBatchSession
		}
	
	switch ($args[$ArgNum])
		{
		-d {$flgDebug = "TRUE"}
		/d {$flgDebug = "TRUE"}
		-debug {$flgDebug = "TRUE"}
		/debug {$flgDebug = "TRUE"}
		-q {$flgVerbose = "FALSE"}
		/q {$flgVerbose = "FALSE"}
		-quiet {$flgVerbose = "FALSE"}
		/quiet {$flgVerbose = "FALSE"}
		-adv {$flgAdvanced = "TRUE"}
		/adv {$flgAdvanced = "TRUE"}
		-advanced {$flgAdvanced = "TRUE"}
		/advanced {$flgAdvanced = "TRUE"}
		-help {DisplayUsage}
		/help {DisplayUsage}
		default {DisplayUsage}
		}
	$ArgNum = $ArgNum + 1
	}

## Begin calling subroutines ##
GetSessionUserID
LoadTPCRServerName
#GetUpdates $zipfile "C:\Storage_Tools\Scripts\Windows" #Tested OK 8/27 
#GetUpdates $verfile "C:\Temp" #Tested OK 8/27 
#CheckBuildVersion
NestedMenus  #Always last
