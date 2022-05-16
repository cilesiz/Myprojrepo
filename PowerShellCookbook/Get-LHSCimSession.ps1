Function Get-LHSCimSession 
{
<#
.SYNOPSIS
    Create CIMSessions to retrieve WMI data.

.DESCRIPTION
    The Get-CimInstance cmdlet in PowerShell V3 can be used to retrieve WMI information
    from a remote computer using the WSMAN protocol instead of the legacy WMI service
    that uses DCOM and RPC. However, the remote computers must be running PowerShell
    3 and WSMAN protocol version 3. When querying a remote computer,
    Get-CIMInstance setups a temporary CIMSession. However, if the remote computer is
    running PowerShell 2.0 this will fail. You have to manually create a CIMSession
    with a CIMSessionOption to use the DCOM protocol. This Script does it for you
    and creates a CimSession depending on the remote Computer capabilities.

.PARAMETER ComputerName
    The computer name(s) to connect to. 
    Default to local Computer

.PARAMETER Credential
    [Optional] alternate Credential to connect to remote computer.

.EXAMPLE
    $CimSession = Get-LHSCimSession -ComputerName PC1
    $BIOS = Get-CimInstance -ClassName Win32_BIOS -CimSession $CimSession
    Remove-CimSession -CimSession $CimSession    

.EXAMPLE
    $cred = Get-Credential Domain01\User02 
    $CimSession = Get-LHSCimSession -ComputerName PC1 -Credential $cred
    $Volume = Get-CimInstance -ClassName Win32_Volume -Filter "Name = 'C:\\'" -CimSession $CimSession
    Remove-CimSession -CimSession $CimSession 

.INPUTS
    System.String, you can pipe ComputerNames to this Function

.OUTPUTS
    Microsoft.Management.Infrastructure.CimSession

.NOTES
    to get rid of CimSession because of testing use the following to remove all CimSessions
    Get-CimSession | Remove-CimSession -whatif

    Most of the CIM Cmdlets do not have a -Credential parameter. The only way to specify 
    alternate credentials is to manually build a new CIM session object, and pass that 
    into the -CimSession parameter on the other cmdlets.

    AUTHOR: Pasquale Lantella 
    LASTEDIT: 
    KEYWORDS: CIMSession

.LINK
    The Lonely Administrator: Get CIMInstance from PowerShell 2.0 
    http://jdhitsolutions.com/blog/2013/04/get-ciminstance-from-powershell-2-0/

#Requires -Version 3.0
#>
   
[cmdletbinding()]  

[OutputType('Microsoft.Management.Infrastructure.CimSession')] 

Param(

    [Parameter(Position=0,Mandatory=$False,ValueFromPipeline=$True,
        HelpMessage='An array of computer names. The default is the local computer.')]
	[alias("CN")]
	[string[]]$ComputerName = $Env:COMPUTERNAME,

    [Parameter()]
    [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
)

BEGIN {

    Set-StrictMode -Version Latest
    ${CmdletName} = $Pscmdlet.MyInvocation.MyCommand.Name

    Function Test-IsWsman3 {
    # Test if WSMan is greater or eqaul Version 3.0
    # Tested against Powershell 4.0
        [cmdletbinding()]
        Param(
        [Parameter(Position=0,ValueFromPipeline)]
        [string]$Computername=$env:computername
        )
 
        Begin {
            #a regular expression pattern to match the ending
            [regex]$rx="\d\.\d$"
        }
        Process {
            $result = $Null
            Try {
                $result = Test-WSMan -ComputerName $Computername -ErrorAction Stop
            }
            Catch {
                # Write-Error $_
                $False
            }
            if ($result) {
                $m = $rx.match($result.productversion).value
                if ($m -ge '3.0') {
                    $True
                }
                else {
                    $False
                }
            }
        } #process
        End {}
    } #end Test-IsWSMan

} # end BEGIN

PROCESS {
    Write-Verbose "${CmdletName}: Starting Process Block"
    Write-Debug ("PROCESS:`n{0}" -f ($PSBoundParameters | Out-String))
    
    ForEach ($Computer in $ComputerName) 
    {
        IF (Test-Connection -ComputerName $Computer -count 2 -quiet) { 

            $SessionParams = @{
                  ComputerName  = $Computer
                  ErrorAction = 'Stop'
            } 
            if ($PSBoundParameters['Credential'])  
            {
                Write-Verbose "Adding alternate credential for CIMSession"
                $SessionParams.Add("Credential",$Credential)
            }


            If (Test-IsWsman3 –ComputerName $Computer)
            {
	            $option = New-CimSessionOption -Protocol WSMan 
	            $SessionParams.SessionOption = $Option      
            }
            Else
            {
	            $option = New-CimSessionOption -Protocol DCOM
	            $SessionParams.SessionOption = $Option 
            }

            New-CimSession @SessionParams
    
        } Else {
            Write-Warning "\\$computer DO NOT reply to ping" 
        } # end IF (Test-Connection -ComputerName $Computer -count 2 -quiet)  
	   
    } # end ForEach ($Computer in $ComputerName)

} # end PROCESS

END { Write-Verbose "Function ${CmdletName} finished." }

} # end Function Get-LHSCimSession                
   
   
         