#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.29
# Created by:   Dustin Hedges
# Filename:     Invoke-BIOSUpdate.ps1
#========================================================================


<#
	.SYNOPSIS
		Takes a BIOS Update input file and supplied arguments and automatically disables BitLocker Protectors to avoid Recovery Mode.
	
	.DESCRIPTION
		Takes a BIOS Update input file and supplied arguments and automatically disables BitLocker Protectors to avoid Recovery Mode.  Does NOT account for BIOS Update applicability.  BIOS Update return code is returned by the script/function.
	
	.PARAMETER UpdateFile
		The full path to the BIOS Update File.
	
	.PARAMETER Arguments
		Optional: Any installation switches required by the update file for silent installation, logging, etc.
		-Arguments "/s /l*v 'C:\Logs\BIOSUpdate.log'
	
	.PARAMETER ComputerName
		LocalHost (Default).  Array, can take input of multiple computer names.
	
	.EXAMPLE
		PS C:\> Invoke-BIOSUpdate -UpdateFile 'C:\Temp\BIOS_10.exe' -Arguments "/s /l*v 'C:\Temp\BIOSUpdate.log'"
		This example shows how to call the Invoke-BIOSUpdate function with named parameters.
	
	.EXAMPLE
		PS C:\> Invoke-BIOSUpdate 'C:\Temp\BIOS_10.exe' "/Silent /l='C:\Temp\BIOSUpdate.log'"
		This example shows how to call the Invoke-BIOSUpdate function with positional parameters.
	
	.OUTPUTS
		System.Int32
	
	.LINK
		http://deploymentramblings.wordpress.com
	
	.INPUTS
		System.String,System.String
#>
[CmdletBinding()]
[OutputType([int32])]
param
(
	[Parameter(Mandatory = $true,
			   ValueFromPipeline = $true,
			   ValueFromPipelineByPropertyName = $true,
			   Position = 1,
			   HelpMessage = 'Full file path to BIOS Update File')]
	[String]$UpdateFile,
	[Parameter(Mandatory = $false,
			   ValueFromPipeline = $true,
			   ValueFromPipelineByPropertyName = $true,
			   Position = 2,
			   HelpMessage = 'Installation Arguments')]
	[System.String]$Arguments
)
begin
{
	# Validate File Path
	if(-Not(Test-Path $UpdateFile)){
		Write-Verbose "File not found at $UpdateFile"
		Exit 1
	}
		
	# Define Full Path to Script Directory if file path starts with '.\'
	if($UpdateFile.StartsWith(".\")){
		$scriptDirectory = Split-Path ($MyInvocation.MyCommand.Path) -Parent
		$UpdateFile = $UpdateFile.Replace(".\", "$ScriptDirectory\")
		Write-Verbose "Updating BIOS using file: $UpdateFile"
	}
}
process {
	# Process Local Computer
	Try{
		switch ($(Get-WmiObject -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume -ErrorAction 'Stop' | Where-Object {$_.DriveLetter -eq $env:SystemDrive}).GetConversionStatus().ConversionStatus) {
			{1..5} {
				#BitLocker is currently enabled, disable protectors
				$manageBDE = "$env:windir\System32\manage-bde.exe"
				
				Write-Verbose "BitLocker is currently enabled.  Disabling Protectors"
				$result = Start-Process -FilePath $manageBDE -ArgumentList "-protectors -disable $($env:SystemDrive)" -NoNewWindow -Wait -ErrorAction SilentlyContinue -PassThru
				Write-Verbose "Manage-BDE Return Code $($result.ExitCode)"
				
				Write-Verbose "Setting RunOnce Key to re-enable BitLocker Protectors"
				New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "BitLocker" -Value "manage-bde.exe -protectors -enable $($env:SystemDrive)" -Force | Out-Null
				break;
			}
			default {
				# Drive not encrypted with BitLocker.  No further action required.
				break;
			}
		}		
			
	}
	Catch{
		$e = $_.Exception
		Write-Verbose $e
		break;
	}
	
	# Execute BIOS Update File
	$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
	$processStartInfo.FileName = "$UpdateFile"
	$processStartInfo.UseShellExecute = $false
	$processStartInfo.RedirectStandardOutput = $true
	$processStartInfo.RedirectStandardError = $true
	if ($Arguments.Length -gt 0)
	{
		$processStartInfo.Arguments = $Arguments
	}
	$processStartInfo.WindowStyle = 'Hidden'
	
	Write-Verbose "Starting BIOS Update Execution"
	$process = [System.Diagnostics.Process]::Start($processStartInfo)
	
	$stdOut = $process.StandardOutput.ReadToEnd() -replace "`0", ""
	$stdErr = $process.StandardError.ReadToEnd() -replace "`0", ""
	
	$process.WaitForExit()
	Write-Verbose "Exit Code: $($process.ExitCode)"
	return $process.ExitCode
}
end {
}
