#COLOR=Yellow
#Requires -Version 1
# PowerShell supports formal scripting
# Any arguments which are not bound to parameters
# are assigned to $args
#Color=

Function Write-Color
{
param (
   [ConsoleColor]$Color
)
#COLOR=Red
    Write-Host -Foreground $Color $Args
#COLOR=
}

#COLOR=Yellow
############ RUN IT #########################
#COLOR=
write-Color -Color Yellow This is YELLOW
Write-Color Red This is RED
write-Color -Color RED Get-Process -Name *ss -OutVariable o -ErrorRecord a 


