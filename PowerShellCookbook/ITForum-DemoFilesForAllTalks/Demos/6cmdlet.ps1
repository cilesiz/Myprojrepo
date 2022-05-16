#Requires -Version 2
cmdlet Get-ProcessThread
{
param(
[Mandatory]
$Name
)

    foreach ($p in Get-Process -Name $name)
    {
        Write-Debug "Process: $($p.Name) $($p.id)"
	$p.Threads |select id
    }
}

Get-ProcessThread -Name *ss
