#COLOR=Yellow
#Requires -Version 1
# This is a sophisticated script.  Notice the following:
#  - It supports pipelining with a Begin/Process/End scriptblocks
#
#COLOR=

function Get-Total ()
{
#COLOR=Red
   Begin
#COLOR=
   {   $total         = 0
       $property      = "Handles"
       $format        = "Total {1} = {0}"
   }

#COLOR=Red
   Process
#COLOR=
   {
       $total += $_.$property 
   }


#COLOR=Red
   End
#COLOR=
   {   $format -f $total, $property
   }
}


#COLOR=Yellow
############ RUN IT #########################
#COLOR=
Get-Process | Get-Total 

