#========================================================================
# Created with: PowerShell ISE
# Created on:   1/16/2014 
# Created by:   nebojsat
# Organization: 
# Filename:     Get-UUID.ps1
#========================================================================

function Get-UUID  {
<#
	.SYNOPSIS
		Fetch UID from remote device
	.DESCRIPTION
		This Function is using WS-MAN (WinRM) to query remote device
		and retreive one of the following: UUID, GUID, or PlatformGUID
	.PARAMETER  ComputerName
		Contains one or more computer names
	.PARAMETER  User
		Username for accessing remote device
	.PARAMETER  Password
		Password for specified username.
    .PARAMETER UID
        Specify which UID to retrieve: 
        UUID (e.g. 4c4c4544-0043-4210-8044-b6c04f385031 )
        smbiosGUID (e.g. 44454c4c-4300-1042-8044-b6c04f385031 )
        PlatformID (e.g. 3150384f-c0b6-4480-4210-00434c4c4544 )
	.EXAMPLE
		Get-UUID -computername remotecomputer -user myuser -password mypassword
	.EXAMPLE
		Get-UUID -computername computer1,computer2 -user myuser -password mypassword
	.EXAMPLE
		Get-Content .\Computers.txt | Get-UUID -user myuser -password mypassword | Out-File .\uuids.txt
	.NOTES
		Function is tested (so far) on DELL's iDRAC7 and iDRAC6
#>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [alias('hostname')]
        [ValidateLength(3,20)]
        [ValidateCount(1,50)]
        [ValidateNotNullOrEmpty()]
        [string[]]$computerName,
        [Parameter(Mandatory=$true)]
        [string]$user,
        [Parameter(Mandatory=$true)]
        [string]$password,
        [Parameter(Mandatory=$true,HelpMessage="Samples: UUID 4c4c4544-0043-4210-8044-b6c04f385031 smbiosGUID 44454c4c-4300-1042-8044-b6c04f385031 PlatformGUID 3150384f-c0b6-4480-4210-00434c4c4544")]
        [ValidateSet("UUID","smbiosGUID","PlatformGUID")]
        [string]$UID,
        [switch]$CreateLog
         )
BEGIN 
  {
            if ($createlog)
                {
                Write-Verbose "Creating new log file"
                $i=0
                do 
                    {
                    $LogFile = "UUID-$i.log"
                    $i++
                    }
                    while (Test-Path $LogFile)
                    Write-Verbose "New log file is $LogFile"

                }
  }
PROCESS
  {
     foreach ($computer in $computerName) 
     {
     if ($PSCmdlet.ShouldProcess($computer)) 
            {
                #test if device is online and accessible
                try {
                    Set-Variable -Name keepgoing -Value $True 
                    $test = Test-Connection -ComputerName $computer -BufferSize 16 -Count 1 -ErrorAction 'Stop' -Quiet
                    }
                    catch {
                           $keepgoing=$false
                           $wo = "Error: " + $computer + " is not accessible"
                           if ($CreateLog){ Write-Output $wo | Out-File -Append $LogFile }
                           Write-Verbose $wo
                           Write-Debug $wo
                          }
                # check compatibility
                if ($keepgoing)
                    {
                    $tryWSMAN = winrm identify -r:https://$computer/wsman -SkipCNCheck -SkipCACheck -u:$user -p:$password -encoding:utf-8 -a:basic -format:pretty
                     } 
                if (!$?)
                    {$keepgoing=$false
                     $wo = "Error: " + $computer + " is not responding to WS-MAN requests"
                     if ($CreateLog){ Write-Output $wo | Out-File -Append $LogFile}
                     Write-Verbose $wo
                     }
                # get UUID
                if ($keepgoing)
                    {
                    [xml]$result = winrm e http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_SystemView `
                    -u:$user `
                    -p:$password `
                    -r:https://$computer/wsman:443 `
                    -auth:basic `
                    -encoding:utf-8 `
                    -format:xml `
                    -SkipCNcheck `
                    -SkipCAcheck

                    switch ($UID)
                    {
                    "UUID" {$VID = $result.Results.DCIM_SystemView.UUID}
                    "smbiosGUID" {$VID = $result.Results.DCIM_SystemView.smbiosGUID}
                    "PlatformGUID" {$VID = $result.Results.DCIM_SystemView.PlatformGUID}
                    }

                    $cuid =  $VID
                    $wo = $computer + ",{" + $cuid + "}"
                    if ($CreateLog)
                        { 
                        Write-Output $wo | Out-File -Append $LogFile
                        }
                     $properties = @{'ComputerName'=$computer;
                                     "$UID"=$cuid
                                     }
                     $obj = New-Object -TypeName psobject -Property $properties
                     Write-Output $obj
                     
                                        
                    }
            }
    }
  }
END
  {
  }
}