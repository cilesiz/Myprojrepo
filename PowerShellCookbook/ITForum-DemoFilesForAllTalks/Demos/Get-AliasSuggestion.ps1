#requires -Version 2
# CTP
cmdlet
param(
# Version 2 (CTP) supports attributes on parameters.
# These attributes cause the engine to do work for us
    [Mandatory]
    [Position(0)]
    [Alias("commandline","Cmd","Line")]
    $lastCommand
)
# Version 2 (CTP) supports a DATA language which can be used for
# globalizing your script
data msgs {
   # Replace this with your own culture/string
   if ($UICulture -eq "en-US")
   {
        @{
            Suggestion = "Suggestion:  An alias for [{0}] is [{1}]"
        }
   }else
   {
        @{
            Suggestion = "Suggestion:  An alias for [{0}] is [{1}]"
        }
   }
}

# Version 2 (CTP) supports a tokenize API so we can take an arbitrary string and
# Tokenize it to extract the COMMAND tokens
$commands = [System.Management.Automation.PSParser]::Tokenize($lastCommand, [ref]$null) | 
    where {$_.Type -eq "Command"} | foreach {$_.Content}
foreach ($alias in Get-Alias)
{
    # Version 2 (CTP) built in aliases now include the SNAPIN name for robustness
    if ($alias.Definition.contains("\"))
    {   $definition = @($alias.Definition -split "\\")[1]
    }else
    {   $definition = $alias.Definition
    }
    if ($commands -contains $definition)
    {   $msgs.Suggestion -f $definition.PadRight(15), $alias.Name.padRight(7)
    }
}

