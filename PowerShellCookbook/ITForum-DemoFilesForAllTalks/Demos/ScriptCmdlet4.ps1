#COLOR=YELLOW
#Requires -Version 2
# VALIDATESCRIPT lets you do anything you want
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
    [ValidateScript({$test}]
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

