#COLOR=YELLOW
#Requires -Version 2
# Simple Cmdlets look like functions
#COLOR=RED
Cmdlet Get-ExportedType
{
param(
    $Name
)
#COLOR=
    # This script returns the first type that matches the NAME provided
    foreach ($a in [AppDomain]::CurrentDomain.GetAssemblies())
    {
        foreach ($t in $a.GetExportedTypes())
        {
            if ($t.Name -match $Name)
            {   $t
                return
            }
        }# foreach $t
    }#foreach $a
}#cmdlet

