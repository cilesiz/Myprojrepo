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
    [VALUEFROMPIPELINEBYPROPERTYNAME]
    [Alias("LastWriteTime","StartTime")]
#COLOR=
    [DateTime]$Date="1/1/2006"
)
process
{
    if ($Date.year -gt 2007)
    {
        Write-Error "Focus on this year not next year!" -TargetObject $Date
    }
    Write-Output $Date.DayOfWeek
}#process
}#cmdlet
