#Requires -Version 2
function child
{
    param(
    $process
    )
    
    "line 7"
    foreach ($g in Get-Process $process)
    {
        Write-Host "HOST: $g.Name"
    }
    $x = 50
    $x
    $x= 44
}

function parent
{
    Param(
        $name
    )
    child $name
}

parent po*
