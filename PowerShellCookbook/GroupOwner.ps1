#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- .

<#
.SYNOPSIS

Change the owner of a SharePoint Group of a Web with another group in the same web

.DESCRIPTION

By Default the the Web's owner group is set as the owner of all the groups of the web.This script can change that to any other group in the same web for any SharePoint Group.

.PARAMETER SpWebUrl

The URL of the Web for which the groups needs to be enumerated or modified. If only this parameter is used then it will list out all the groups in the web with their owners.

.PARAMETER listGroups

This parameters is optional and it has no effect of the functioning of the script if used along with Group and OwnerGroup parameters, it will list out all the groups after making changes.
The parameter is automatically enabled when the script is run in read-only mode ( only with WebUrl parameter )

.PARAMETER Group

The Owner for which the owner needs to be changed/updated.

.PARAMETER OwnerGroup 

The Group that needs to become the owner of the group speficied in Group Parameter

.EXAMPLE

GroupOwner.ps1 -WebUrl http://sp20
 Lists out all the groups in a web (Read-only)



.EXAMPLE

GroupOwner.ps1 -WebUrl http://sp2010 -Group "Designers" -OwnerGroup "Team Site Owners" -ListGroups

Updates the group owner with another group and list out all the groups after making changes

.EXAMPLE

GroupOwner.ps1 -WebUrl http://sp2010 -Group "Designers" -OwnerGroup "Team Site Owners"

Updates the group owner with another group and list does not emit the groups in the output

#>
param([parameter(Mandatory=$true)][string]$SpWebUrl,
      [parameter(Mandatory=$false)][string]$Group,
      [parameter(Mandatory=$false)][string]$OwnerGroup,
      [parameter(Mandatory=$false)][switch]$listGroups)

#requires –PsSnapIn Microsoft.SharePoint.Powershell
try
{

    $spweb = $null
    $Spweb = Get-spweb $SpWebUrl -ErrorAction Stop
    
    if ( $Group -ne '' -and $OwnerGroup -ne '')
    {
            $Spweb.Groups[$Group].owner = $SpWeb.Groups[$OwnerGroup]
            $Spweb.Groups[$Group].update()
            Write-Output "Group owner Updated..."
    }
    else
    {
        Write-output "Either Group or GroupOwner Parameter missing. Listing groups Only" 
        $listgroups = [switch]::Present
    }

    if ( $listgroups )
    {
        
        $spweb = Get-spweb $SpWebUrl -ErrorAction Stop
        $GroupsHashTable = @{}
        $SpWeb.groups | % {  $GroupsHashTable.Add($_.Name,$_.Owner.Name) }
        $GroupsHashTable | FT -AutoSize @{Expression ={$_.Name}; Label="Group Name"}, @{Expression = {$_.Value};Label="Owner Group Name"} 
        $GroupsHashTable.Clear()           
    }

}

catch 
{
    if ( $_.FullyQualifiedErrorId -match 'PropertyNotFound') 
    { 
        Write-output "Error : Group Name not correct or is not a group"
    }
    elseif ( $_.FullyQualifiedErrorId -match 'PropertyAssignmentException') 
    { 
        Write-output "Error : Owner Group Name not correct or is not a group"
    }
    Else 
    { 
        Write-Output "Error : $($_.Exception.Message)"
    }
}

finally
{
    
    if ( $Spweb -ne $NULL ) 
    { 
        Write-Output "Disposing SpWeb..." 
        $spweb.Dispose()
    }
}