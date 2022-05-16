#COLOR=YELLOW
#Requires -Version 2
# ValueFromPipeline allows pipeline values to the parameter
#  (which explains the name :-) )
#COLOR=
Cmdlet Get-DayofWeek
{
param(
    [MANDATORY]
    [POSITION(0)]
#COLOR=RED
    [VALUEFROMPIPELINE]
#COLOR=
    [DateTime]$Date="1/1/2006"
)
process
{
    Write-Output $Date.DayOfWeek
}#process
}#cmdlet
