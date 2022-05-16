#COLOR=Yellow
#Requires -Version 1
# This is a sophisticated script.  Notice the following:
#  - Parameters are Named, Typed, and have Initializers
#  - It uses a Begin/Process/End blocks
#  - It uses ScriptBlocks
#
#COLOR=

function Get-Total ()
{
param(
[String]$property     = $(throw "Property Name Required"),
#COLOR=RED
[ScriptBlock]$filter  = {$true}
#COLOR=
)

   Begin
   {   $total         = 0
   }

   Process
   {
#COLOR=RED
       if ($_ |where $filter)
#COLOR=
       {   $total += $_.$property 
       }
   }


   End
   {   "Total $property = $total"
   }
}


#COLOR=Yellow
############ RUN IT #########################
#COLOR=
Get-Process | Get-Total Handles
Get-Process | Get-Total Handles {$_.name -eq "SVCHOST"}
