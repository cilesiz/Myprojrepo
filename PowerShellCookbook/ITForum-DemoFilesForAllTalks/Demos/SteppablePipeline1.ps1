#Requires -Version 2
Cmdlet Measure-Process
{
param(
[ValueFromPipeline]
$proc
)
process
{
   $proc |Measure-Object -Max -Min -Ave -Property handles
}
}

Get-Process *ss |Measure-Process
