#COLOR=Yellow
#Requires -Version 1
# PowerShell supports formal scripting
# The parameters in this script have:
#   -Names
#   -Types
#   -Initializers
#Color=
$Script:Usage = "USAGE: Get-Total -InputObject <objects[]> -Property <propertyname> [-Format <formatstring>]"

Function Get-Total
{
#COLOR=RED
param (
   $InputObject      = {Throw $Script:USAGE},
   [String]$property = "Handles",
   [String]$Format   = "Total {1} = {0}"
)
#COLOR=
$total = 0
foreach ($i in @($inputObject))
{
   $total += $i.$property
}
$format -f $total, $property
}

#COLOR=Yellow
############ RUN IT #########################
#COLOR=
Get-Total -Input (Get-Process)
Get-Total -Input (Get-Process) -Property WorkingSet
Get-Total -Input (Get-Process) -Property WorkingSet -format "There are a total of {0} {1}"
#COLOR=Yellow
# Named parameters allow 
#   -- Arbitrary ordering
#COLOR=Red
Get-Total  -format "There are a total of {0} {1}" -Property WorkingSet  -Input (Get-Process)
#COLOR=Yellow
#   -- Partial naming 
#COLOR=Red
Get-Total -I (Get-Process) -P WorkingSet
#COLOR=Yellow
#   -- positional invocation
#COLOR=Red
Get-Total (Get-Process) WorkingSet
 
