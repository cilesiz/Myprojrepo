#COLOR=YELLOW
#Requires -Version 2
# VALIDATESET specifies what values are acceptable
#COLOR=
Cmdlet Get-ExportedType
{
param(
    [MANDATORY]
    [HelpMessage("Short name of the type [no namespace]")]
    [POSITION(0)]
    [Alias("TypeName","tn")]
    [ValidateNotNullOrEmpty]
#COLOR=RED
    [ValidateSet("AppDomain","PSParser")]
#COLOR=
    $Name
)
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

