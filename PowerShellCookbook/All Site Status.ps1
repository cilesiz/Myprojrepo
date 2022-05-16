## ===================================================================== 
## Description : Get IIS 7.0 All Site Status
##             : Uses IIS 7.0 PowerShell Provider
## Usage       : PS> .\Get-IIS7AllSiteStatus
## Notes       : Credit to Jeong's Blog at http://blogs.iis.net/jeonghwan/default.aspx
## ===================================================================== 

param
(
	[switch]$verbose = $true,
	[switch]$debug = $false
)
function main()
{
	if ($verbose) {$VerbosePreference = "Continue"}
	if ($debug) {$DebugPreference = "Continue"}
	
    if (LoadIIS7Module -eq $true)  {
        Write-Verbose "Get IIS 7.0 All Site Status..."
        Get-IIS7AllSiteStatus
    } else {
        Write-Host "IIS7 WebAdministration Snapin or Module not found."
        Write-Host "Please consult the Microsoft documentation for installing the IIS7 PowerShell cmdlets"
    }
}

function Get-IIS7AllSiteStatus()
{
	trap [Exception] 
	{
		write-error $("TRAPPED: " + $_.Exception.Message);
		continue;
	}

	dir IIS:\Sites | Format-Table
}

function LoadIIS7Module () {
    $ModuleName = "WebAdministration"
    $ModuleLoaded = $false
    $LoadAsSnapin = $false
    if ((Get-Module -ListAvailable | 
        ForEach-Object {$_.Name}) -contains $ModuleName) {
        Import-Module $ModuleName
        if ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName) {
            $ModuleLoaded = $true
        } else {
            $LoadAsSnapin = $true
        }
    }
    elseif ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName) {
        $ModuleLoaded = $true
    } else {
        $LoadAsSnapin = $true
    }
    if ($LoadAsSnapin) {
        if ((Get-PSSnapin -Registered | 
            ForEach-Object {$_.Name}) -contains $ModuleName) {
            Add-PSSnapin $ModuleName
            if ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName) {
                $ModuleLoaded = $true
            }
        }
        elseif ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName) {
            $ModuleLoaded = $true
        }
        else {
            $ModuleLoaded = $false
        }
    }
    return $ModuleLoaded
}

main
