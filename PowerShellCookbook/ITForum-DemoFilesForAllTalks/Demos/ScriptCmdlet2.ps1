#COLOR=YELLOW
#Requires -Version 2
# One of the BIG differences is that Cmdlet Parameters 
# can take attributes.  The great thing about that is that
# you get MORE functions for LESS code and it providers 
# users a more CONSISTENT user-experience.
#COLOR=
Cmdlet Get-ExportedType
{
param(
#COLOR=RED
    [MANDATORY]
    [HelpMessage("Short name of the type [no namespace]")]
    [POSITION(0)]
    [Alias("TypeName","tn")]
    [ValidateNotNullOrEmpty]
    [ValidatePattern("^AP")]
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

