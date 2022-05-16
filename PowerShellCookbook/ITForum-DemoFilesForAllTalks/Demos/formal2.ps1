#COLOR=Yellow
#Requires -Version 1
# PowerShell supports formal scripting
# Typing parameters allows PowerShell do coerce datatypes for you
#Color=

Function DaysTill
{
#COLOR=RED
param (
   [DateTime]$Date
)
#COLOR=
     ($date - [DateTime]::Now).Days
}

#COLOR=Yellow
############ RUN IT #########################
#COLOR=
DaysTill (New-Object System.DateTime 2007,12,25)
DaysTill "12/25/2007"
DaysTill 12/25/2007
