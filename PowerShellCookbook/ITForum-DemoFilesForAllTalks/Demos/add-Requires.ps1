#Requires -Version 2
cmdlet add-requires -SupportsShouldProcess
{
param(
[valuefrompipelinebypropertyname]
[ALIAS("name")]
$fullname
)
process {
    if (!(dir $fullname |Select-String "^#Requires.*-Version"))
    {
        if ($cmdlet.ShouldProcess("Add-Requires", $fullname))
        {
            $content = Get-Content $fullname
            Set-Content -path $fullname  -value ("#Requires -Version 2", $content) -verbose
        }
        else
        {
            Write-Verbose "Skipping $fullname"
        }
    }else
    {   Write-Verbose "$Fullname already has #Requires"
    }
}
}

dir g:\ctp\demos sc*.ps1 |add-requires  -verbose 
